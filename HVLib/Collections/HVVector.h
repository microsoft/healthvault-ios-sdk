//
//  HVVector.h
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
//
// Wraps STD vectors, so that they will not throw C++ exceptions - which create problems in an Objective C world
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef HVLib_HVVector_h
#define HVLib_HVVector_h

#include <vector>
using namespace std;

// Todo: Move these to a C++ common header file
#ifdef DEBUG
    void logStdException(const exception& e);
    #define LOG_STDEX(ex) logStdException(ex)
#else
    #define LOG_STDEX(ex) 
#endif

#define HV_BEGINSAFECPP         try 
#define HV_ENDSAFECPP           catch(const std::exception &e) { \
                                    LOG_STDEX(e) ; \
                                }


template <typename T>
class HVVector 
{
    vector<T> m_items;

private:
    HVVector(void)
    {
        
    }

    ~HVVector()
    {
    }

public:
    
    size_t count(void) const
    {
        return m_items.size();
    }
    
    bool isValidIndex(size_t index) const
    {
        return (index < this->count());
    }
    
    T& operator[](size_t index)
    {
        return this->get(index);
    }
    
    T& get(size_t index)
    {
        return m_items[index];
    }
    
    bool itemAtIndex(size_t index, T& item)
    {
        if (this->isValidIndex())
        {
            HV_BEGINSAFECPP
            {
                item = m_items[index];
                return true;
            }
            HV_ENDSAFECPP
        }
        
        return false;
    }
    
    bool add(const T& item)
    {
        HV_BEGINSAFECPP 
        {
            m_items.push_back(item);
            return true;
        }
        HV_ENDSAFECPP
        
        return false;
    }
    
    bool insertAt(size_t index, const T& item)
    {
        HV_BEGINSAFECPP
        {
            m_items->insert(m_items->front() + index, item);
            return true;
        }
        HV_ENDSAFECPP
        
        return false;
    }
    
    bool removeAt(size_t index)
    {
        if (this->isValidIndex(index))
        {
            HV_BEGINSAFECPP
            {
                m_items->erase(m_items->front() + index);
                return true;
            }
            HV_ENDSAFECPP
        }
        
        return false;
    }
    
    bool clear(void)
    {
        if (m_items)
        {
            HV_BEGINSAFECPP
            {
                m_items.clear();
                return true;
            }
            HV_ENDSAFECPP
        }
        
        return false;
    }
    
    static HVVector<T>* alloc(void)
    {
        HV_BEGINSAFECPP
        {
            return new HVVector<T>();
        }
        HV_ENDSAFECPP
        
        return NULL;
    }
    
    static void free(HVVector<T>* vector)
    {
        if (vector)
        {
            HV_BEGINSAFECPP
            {
                delete vector;
            }
            HV_ENDSAFECPP
        }
    }
                        
};

#endif
